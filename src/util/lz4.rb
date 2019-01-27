require_relative 'io.rb'

class Lz4Util
    def self.decompress(data)
        r = BinaryReader.new(data)
        
        token = 0
        sqSize = 0
        matchSize = 0
        litPos = 0
        offset = 0
        retCurPos = 0
        endPos = 0

        r.seekAbs(4)
        decompressedSize = r.readIntLE
        dataSize = r.readIntLE
        endPos = dataSize + 16
        retArray = Array.new(decompressedSize, 0)

        r.seekAbs(16)

        loop do
            # read the LiteralSize and the MatchSize
            token = r.readByte
            sqSize = token >> 4
            matchSize = (token & 0x0F) + 4
            if sqSize == 15 then
                sqSize += readAdditionalSize(r)
            end

            # copy the literal
            r.copyBytes(retArray, retCurPos, sqSize)
            retCurPos += sqSize

            if r.getPos >= endPos - 1 then
                break
            end

            # read the offset
            offset = r.readShortLE

            # read the Additional MatchSize
            if matchSize == 19 then
                matchSize += readAdditionalSize(r)
            end

            # copy the match properly
            if matchSize > offset then
                matchPos = retCurPos - offset
                loop do
                    copyWithin(retArray, retCurPos, matchPos, matchPos + offset)
                    retCurPos += offset
                    matchSize -= offset
                    if matchSize < offset
                        break
                    end
                end
            end
            copyWithin(retArray, retCurPos, retCurPos - offset, retCurPos - offset + matchSize)
            retCurPos += matchSize
        end
        return retArray.pack("C*")
    end

    private
    def self.readAdditionalSize(r)
        size = r.readByte()
        if size == 255
            return size + readAdditionalSize(r)
        else
            return size
        end
    end

    private
    def self.copyWithin(ary, target, start, endpos)
        (endpos - start).times do |i|
            ary[target + i] = ary[start + i]
        end
    end
end

