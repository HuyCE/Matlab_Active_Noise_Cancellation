classdef class_AdaptiveFIlter
   properties
      N = 0
      w = 0
      mu = 0
      m0 = 0
      m1 = 0
      vsnlms = class_VSNLMS(self.mu, mu_max, mu_min, m0, m1, alpha, delta)
      inp_signal = zeros(N)
      err = 1
   end
   methods
      function obj = init(obj, N, mu, mu_max, mu_min, m0_per, m1_per, alpha, delta)
        if mu == 1e-3
          mu=1e-3;
          mu_max=1.1; 
          mu_min=1e-9;
          m0_per=0.9; 
          m1_per=0.9; 
          alpha=10; 
          delta=0.0;
        end
        obj.N = N;
        obj.w = np.random.randn(N);
        obj.mu = mu;
        obj.m0 = m0_per * N;
        obj.m1 = m1_per * N;
        obj.vsnlms = VSNLMS(self.mu, mu_max, mu_min, m0, m1, alpha, delta);
        obj.inp_signal = list(np.zeros(N));
        obj.err = 1;
      end

      function obj = fit(obj, input_signal, desired_signal)
      %FIT  Function to update the weights of an adaptive filter to match the desired response.
      %   obj = FIT(obj, input_signal, desired_signal) updates the internal state
      %   (weights, input buffer, error) of the adaptive filter object 'obj'.
      %
      %   Inputs:
      %     input_signal: Vector input to the adaptive filter.
      %     desired_signal: Vector of the desired signal for the adaptive filter.

          % Initialize the input signal buffer (equivalent to self.inp_signal in Python)
          % In MATLAB, it's often more efficient to pre-allocate.
          % Assuming obj.N is already defined as the filter order.
          obj.inp_signal = zeros(1, obj.N); % Initialize with zeros as a row vector

          % Initialize error (obj.err will be updated in the loop)
          obj.err = 1; % Or set to a more appropriate initial value if known

          % Iterate through input and desired signals
          % We use a simple for loop as tqdm is removed.
          num_samples = length(input_signal);
          for k = 1:num_samples
              x = input_signal(k); % Current input sample
              d = desired_signal(k); % Current desired sample

              % Update the input signal buffer (equivalent to append and pop(0))
              % Shift elements left and add new sample at the end.
              obj.inp_signal = [obj.inp_signal(2:end), x];

              % Calculate the error: d - dot product of input buffer and weights
              % np.dot(a, b) for 1D arrays is equivalent to dot(a, b) or sum(a .* b) in MATLAB.
              obj.err = d - dot(obj.inp_signal, obj.w);

              % Update LMS weights (assuming updateLMS is another method of the class)
              % This method must also return the modified object if obj is a value class.
              obj = updateLMS(obj); % Call the updateLMS method
          end
      end

      function filterParameters = getFilterParameters(obj)
        filterParameters = flip(obj.w);
      end

      function obj = updateLMS(obj)
        obj.w = obj.vsnlms.CalNewCoef(obj.w, obj.inp_signal, obj.err);
      end

      function mu = getMu(obj)
        mu = obj.vsnlms.getMu();
      end

      function fillResult = applyFilterSame(obj, input)
        fillResult = conv(input, flip(obj.w), mode="same");
      end

      function fillFullResult = fillapplyFilterFull(obj, input)
        fillFullResult = conv(input, flip(obj.w), mode="full");
      end

      function obj =  resetInput(obj)
        obj.inp_signal = zeros(obj.N);
      end

      function [obj, temp_result] = applyFilterToTap(obj, tap)
        obj.inp_signal.append(tap);
        obj.inp_signal.pop(0);
        temp = obj.applyFilterFull(obj.inp_signal);
        temp2 = temp[self.N - 1];
      end

      function obj = fitFilterWithErrorTap(obj, input_vector, e_tap)
        obj.err = e_tap;
		    obj.w = obj.vsnlms.calcNewCoef(obj.w, input_vector, obj.err);
      end

      function obj = fitFilterWithDesired(self,d_tap)
        obj.err = d - dot(obj.inp_signal, obj.w);
		    obj.updateLMS();
      end

      function obj = setInputVector(obj, input)
         if length(input) ~= obj.N
          disp('The size of the filter did not match the input vector entered');
         end
         obj.inp_signal = input;
      end
   end
end