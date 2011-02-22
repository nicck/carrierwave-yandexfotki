module YandexFotki

  class Encryptor
    class << self
      def encrypt(key, data)
        public_key, text = key, data 

        nstr, estr = public_key.split("#")
        data_arr = []
        text.each_byte {|b| data_arr << b}

        n, e, step_size = nstr.hex, estr.hex, nstr.size/2-1

        prev_crypted = Array.new(step_size, 0)

        hex_out = ""

        ((data_arr.size-1)/step_size+1).times do |i|
          tmp = data_arr[i*step_size...(i+1)*step_size]

          new_tmp = []
          tmp.each_with_index {|t,ii| new_tmp << (t^prev_crypted[ii])}
          tmp = new_tmp.reverse

          plain = 0
          tmp.each_with_index {|t,ii| plain += t*(256**ii%n)}
          hex_result = "%x" % power_modulo(plain, e, n) # plain ** e % n
          hex_result = hex_result.rjust(nstr.size, '0')

          (0...[hex_result.size, prev_crypted.size*2].min).step(2) do |x|
            prev_crypted[x/2] = hex_result[x...(x+2)].hex
          end

          hex_out += (tmp.size < 16 ? "0" : "") + ("%x" % tmp.size) + "00"
          ks = nstr.size/2

          hex_out += (ks < 16 ? "0" : "") + ("%x" % ks) + "00"
          hex_out += hex_result
        end

        hs = []
        hex_out.scan(/../).each{|x| hs << x.hex.chr}
        hs = hs.join
        Base64.encode64(hs).gsub("\n","")
      end

      private

      # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/71964
      def power_modulo(b, p, m)
        if p == 1
          b % m
        elsif (p & 0x1) == 0 # p.even?
          t = power_modulo(b, p >> 1, m)
          (t * t) % m
        else
          (b * power_modulo(b, p-1, m)) % m
        end
      end
    end
  end

end
