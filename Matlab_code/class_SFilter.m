classdef class_SFilter
   properties
      M;
      prevValues;
   end
   methods
      function obj = class_SFilter(M)
        if nargen > 0
          obj.M = M;
        else
          obj.M = 2; 
        end
		    obj.prevValues = zeros(obj.M);
      end
      function [obj, y] = getOutput(obj, x)
            g = 0.5;

            y_len = length(x);
            y = zeros(1, y_len);

            extended_y_buffer = zeros(1, obj.M + y_len);
            extended_y_buffer(1:obj.M) = obj.prevValues;

            for n_current_block_idx = 1:y_len
                y_buffer_write_idx = obj.M + n_current_block_idx;

                y(n_current_block_idx) = x(n_current_block_idx) - ...
                                          g * extended_y_buffer(n_current_block_idx) - ...
                                          0.3 * extended_y_buffer(n_current_block_idx + 1);

                extended_y_buffer(y_buffer_write_idx) = y(n_current_block_idx);
            end

            obj.prevValues = extended_y_buffer(end - obj.M + 1 : end);
      end

      function obj = resetPrevValues(obj)
        obj.prevValues = zeros(obj.M);
      end
   end
end