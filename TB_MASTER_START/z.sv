

module WidthParamProblem ( inclk, led );

/// PARAMETERS ///

parameter counter = 8;

/// FUNCTIONS ///

function automatic int clogb2 (input int number);
    int calc;
    begin
      for (int i = 0; 2**i < number; i++) calc = i + 1;
        clogb2 = (number == 0) ? 0 : (number == 1) ? 1 : calc;
    end
endfunction

/// PORTS ///

input inclk;
output logic [clogb2(counter):0] led = '0;

/// BODY ///

always_ff @ (posedge inclk)
	led <= led + 1'b1;

endmodule