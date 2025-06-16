classdef class_FXLMS
   properties
      alpha = 0
   end
   methods
      function obj = class_FXLMS(alpha)
         obj.alpha = alpha;
      end

      function [obj, new_coef] = calcNewCoef(obj, a_n, signal, error_n, alpha)
         obj.alpha = alpha;
         new_coef = a_n + 2 * obj.alpha * signal * error_n
      end
   end
end