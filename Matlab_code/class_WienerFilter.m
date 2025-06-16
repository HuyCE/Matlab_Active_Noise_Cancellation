classdef class_WienerFilter
   properties
      N;
      a;
      alpha;
      fxlms;
      prevValues;
      counter;
      X;
   end
   methods
      function obj = class_WienerFilter(n, alpha)
        if nargen > 0
          obj.N = n;
          obj.a = np.zeros(obj.N);
          obj.alpha = alpha;
          obj.fxlms = FXLMS(obj.alpha);
          obj.prevValues = zeros(obj.N);
          obj.counter = 0;
          obj.X = [];
        else
          obj.N = 4;
          obj.a = np.zeros(obj.N);
          obj.alpha = alpha;
          obj.fxlms = FXLMS(obj.alpha);
          obj.prevValues = zeros(obj.N);
          obj.counter = 0;
          obj.X = [];
        end
      end

      function [obj, y] = getOutput(obj, x)
            L = length(x);
            y = zeros(1, L);
            
            x_tot = [obj.prevValues, x];
            obj.X = x_tot;

            for n_idx = 1:L
                temp = 0;
                n_tot_idx = n_idx + obj.N; % MATLAB 1-based index equivalent to Python's n_tot

                for i_idx = 2:length(obj.a) % MATLAB loop from 2 to length(obj.a) (Python's 1 to len(self.a)-1)
                    if n_tot_idx > (i_idx - 1) % Python: n_tot > i, MATLAB: n_tot_idx > (i_idx-1)
                        temp = temp - x_tot(n_tot_idx - (i_idx - 1)) * obj.a(i_idx);
                    end
                end
                
                y(n_idx) = -obj.a(1) * x(n_idx) + temp; % Python: self.a[0] is MATLAB obj.a(1)

                if y(n_idx) > 2
                    y(n_idx) = 2;
                elseif y(n_idx) < -2
                    y(n_idx) = -2;
                end
            end
            
            % Update prevValues
            start_idx_x = L - obj.N + 1;
            obj.prevValues = x(start_idx_x:end);
        end

      function obj = updateCoefs(obj, signal, error_n)
            if obj.alpha > 1e-6
                % Calls a method on another object (obj.fxlms).
                % If fxlms.calcNewCoef modifies obj.a and fxlms is a value class,
                % obj.fxlms might also need to be reassigned.
                % Assuming calcNewCoef returns the new 'a' values.
                obj.a = obj.fxlms.calcNewCoef(obj.fxlms, obj.a, signal, error_n, obj.alpha);
            end
      end

      function obj = updateAlpha(obj, decreace)
        if decreace
          obj.alpha = obj.alpha  /2.0;
        elseif alpha
          obj.alpha = obj.alpha * 2.0;
        end
      end

      function obj = resetPrevValues(obj)
        obj.prevValues = zeros(N)
        obj.X = []
      end
   end
end