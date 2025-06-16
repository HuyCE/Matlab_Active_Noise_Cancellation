classdef class_Filter
   properties
      coefs = 0
   end
   methods
      function obj = init(coefs)
        obj.coefs = coefs;
      end

      function Res = applyFilter(obj, input)
        Res = conv(input, obj.coefs, "full")
      end

      function Len = getFilterLen(obj)
        Len = lenght(obj.coesf)
      end

      function Coef = getCoefs(obj)
        Coef = obj.coefs
      end
   end
end