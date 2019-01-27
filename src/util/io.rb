class BinaryReader
    def initialize(data)
        @ary = data.unpack("C*")
        @curPos = 0
    end

    def readByte()
        @curPos += 1
        return @ary[@curPos - 1]
    end

    def readShortLE()
        @curPos += 2
        return @ary[@curPos - 2] + (@ary[@curPos - 1] << 8)
    end

    def readIntLE()
        @curPos += 4
        return @ary[@curPos - 4] + (@ary[@curPos - 3] << 8) + (@ary[@curPos - 2] << 16) + (@ary[@curPos - 1] << 24)
    end

    def readBytes(length)
        ret = @ary.slice(@curPos, length)
        @curPos += length
        return ret
    end

    def copyBytes(dst, offset, length)
        length.times do |i|
            dst[offset + i] = @ary[@curPos + i]
        end
        @curPos += length
    end

    def seekAbs(pos)
        @curPos = pos
    end

    def seekRel(diff)
        @curPos += diff
    end

    def getPos()
        return @curPos
    end

    def readable?()
        return @curPos < @ary.length
    end
end
