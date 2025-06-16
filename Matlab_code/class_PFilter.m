classdef class_PFilter
   properties
      order;
      prevValues;
   end
   methods
      function obj = class_PFilter(order)
        if nargen > 0
          obj.order = order;
        else
          obj.order = 4; 
        end
		    obj.prevValues = zeros(obj.order);
      end
      function [obj, y] = getOutput(obj, x)
         x_tot= [obj.prevValues, x];
         y = zeros(lenght(x));

         for m_idx = 1:length(y)
                n_idx = m_idx + length(obj.prevValues);

                % Apply the filter coefficients.
                % x_tot[n] becomes x_tot(n_idx)
                % x_tot[n-1] becomes x_tot(n_idx - 1) etc.
                y(m_idx) = x_tot(n_idx) + ...
                           0.5 * x_tot(n_idx - 1) + ...
                           0.25 * x_tot(n_idx - 2) + ...
                           0.125 * x_tot(n_idx - 3) + ...
                           0.01 * x_tot(n_idx - 4);
          end

          start_idx_x = length(x) - obj.order + 1;
          obj.prevValues = x(start_idx_x:end);

      end

      function obj = resetPrevValues(obj)
        obj.prevValues = zeros(obj.order)
      end
   end
end