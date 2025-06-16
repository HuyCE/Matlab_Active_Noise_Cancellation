classdef class_VSNLMS
   properties
      mu = 0;
      count_mu_values = 0;
		mu_max = 0;
		mu_min = 0;
		alpha = 0;
		m0 = 0;
		m1 = 0;
		prev_sign = 0
		delta = 0;
		prev_grad = 0;
      Value {mustBeNumeric}
   end
   methods
      function obj = init(obj, mu, mu_max, mu_min, m0, m1, alpha, delta)
         obj.mu = mu;
         obj.count_mu_values = 0;
         obj.mu_max = mu_max;
         obj.mu_min = mu_min;
         obj.alpha = alpha;
         obj.m0 = m0;
         obj.m1 = m1;
         obj.prev_sign = 0;
         obj.delta = delta;
         obj.prev_grad = 0;
      end

      function obj,new_Coefficient = CalNewCoef(obj, a_n, signal, error)
         grad = signal * error;
         if ~isempty(obj.prev_grad)
            % Tính toán dấu của gradient hiện tại
            signed_grad = sign(grad);

            % Điều kiện để giảm bước nhảy (mu)
            if sum(signed_grad ~= obj.prev_grad) > obj.m0 && obj.mu > obj.mu_min
               obj.mu = obj.mu / obj.alpha;
            % Điều kiện để tăng bước nhảy (mu)
            elseif sum(signed_grad == obj.prev_grad) > obj.m1 && obj.mu < obj.mu_max
               obj.mu = obj.mu * obj.alpha;
            end
         end

         obj.prev_grad = sign(grad);
         new_Coefficient = a_n +  obj.mu * grad / (dot(signal, signal)+obj.delta);
      end

      function mu = getMu(obj)
         mu = obj.mu;
      end
   end
end