require 'io/console'

class Commander
    def initialize(prompt)
        @cmd = {"exit" => ExitCommand.new}
        @cands = ["exit"]
        @prompt = prompt + "> "
    end

    # command is a command object which satisfies the following spec:
    # Methods
    #   + call(ARGV)
    #       method which is called when the command is executed.
    #       Arguments including the command itself are passed as an array of string to `ARGV`.
    #       Should return true or false;
    #          true for continue the commander,
    #          false for terminate the commander.
    #   + search(ARGV, prefix) (optional)
    #       method which is called when completion is leased.(TAB pressing)
    #       Arguments including the command itself are passed as an array of string to `ARGV`.
    #       incomplete argument (target word of completion) is passed to `prefix``.
    #       Should return sorted candidates of the completion as an array of string
    def add(name, command)
        @cmd[name] = command
        @cands.push(name)
    end

    # entrypoint of the commander
    # commands must be added using `add` before launching the commander
    def run()
        @cands.sort!
        loop do
            print @prompt
            cmdline = getcmdline
            putc "\n"
            cmds = cmdline.split
            if !exec(cmds) then
                break
            end
        end
    end

    # directly execute a command using given args
    def exec(cmds)
        if cmds.length == 0 then
        elsif !@cmd.has_key?(cmds[0]) then
            cmderr(cmds[0])
        elsif !@cmd[cmds[0]].call(cmds) then
            return false
        end
        return true
    end

    private
    def getcmdline()
        cmdline = ""
        loop do
            c = read_char
            case c
                when "\r" #RETURN
                    break
                when "\t" #TAB

                    # split commands
                    cmds = cmdline.split
                    if cmdline.end_with?(" ") || cmds.length == 0 then
                        cmds.push("")
                    end

                    prefix = cmds[-1]

                    # Get the candidates
                    if cmds.length == 1 then # completion from @cands
                        cands = filter(prefix, @cands)
                    else
                        cmd = @cmd[cmds[0]]
                        if cmd == nil or !cmd.respond_to?("search") then
                            next
                        end
                        cands = cmd.search(cmds, prefix)
                    end
                    if cands == nil or cands.length == 0 then
                        next
                    end

                    # Complete the word
                    comp = comp(prefix, cands)

                    # Show candidates if completion is maximized
                    if comp == prefix and cands.length >= 2 then
                        show_array_interrupt(cands, cmdline)
                        next
                    end

                    # if not completable, do nothing
                    if comp == nil then
                        next
                    end

                    # update cmdline
                    completed = comp.slice(prefix.length, comp.length)
                    print(completed)
                    cmdline.concat(completed)
                    # add space when whole word is completed
                    if cands.length == 1 then
                        print " "
                        cmdline.concat(" ")
                    end
                when "\177" #BACKSPACE
                    if cmdline.length > 0 then
                        cmdline.slice!(cmdline.length - 1)
                        print "\e[D\e[1P" #move backward
                    end
                when "\u0003" #CONTROL-C
                    exit 0
                when /^.$/
                    putc(c)
                    cmdline.concat(c)
            end
        end

        return cmdline
    end

    def puts_interrupt(string, cmdline)
        puts ""
        puts string
        print @prompt
        print cmdline
    end

    def p_interrupt(obj, cmdline)
        puts ""
        p obj
        print @prompt
        print cmdline
    end

    def show_array_interrupt(ary, cmdline)
        puts ""
        if ary.length > 30 then
            print "show all #{ary.length} entries? (y or n) "
            c = read_char
            if c != "y" then
                puts ""
                print @prompt
                print cmdline
                return
            end
        end

        ary.each do |e|
            puts e
        end

        print @prompt
        print cmdline
    end

    def read_char
      STDIN.echo = false
      STDIN.raw!

      input = STDIN.getc.chr
      if input == "\e" then
        input << STDIN.read_nonblock(3) rescue nil
        input << STDIN.read_nonblock(2) rescue nil
      end
    ensure
      STDIN.echo = true
      STDIN.cooked!

      return input
    end

    private
    def cmderr(cmd)
        puts "unknown command '#{cmd}'"
    end


    private
    def filter(prefix, cands)
        i1 = -1
        i2 = -1
        cands.length.times {|i|
            if i1 == -1 then
                if cands[i].start_with?(prefix) then
                    i1 = i
                end
            elsif !cands[i].start_with?(prefix) then
                i2 = i - 1
                break
            end
        }
        if i1 == -1 then
            return []
        end
        if i2 == -1 then
            i2 = cands.length - 1
        end
        return cands[i1..i2]
    end

    private
    def comp(prefix, cands)
        if cands.length == 0 then
            return nil
        end

        str1 = cands[0]
        str2 = cands[-1]
        return findcoprefix(str1, str2)
    end

    private
    def findcoprefix(str1, str2)
        len = [str1.length, str2.length].min
        len.times {|i|
            if !str2.start_with?(str1.slice(0, i)) then
                return str1.slice(0, i - 1)
            end
        }
        return str1.slice(0, len)
    end
end

class ExitCommand
    def call(args)
        return false
    end
end
