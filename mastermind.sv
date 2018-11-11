//Shawnna Cabanday
// March 6, 2018

module mastermind(Clock, SW, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, KEY, LED);
	input [9:0] SW;
	input Clock;
	input [1:0] KEY;
	output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
	output logic LED;
	
	reg [1:0] code3, code2, code1, code0;
	logic [1:0] guess3, guess2, guess1, guess0; 
	logic match_signal3, match_signal2, match_signal1, match_signal0;
	logic [7:0] fullCode, savedCode;
	
	randomNumGenerator codeSequence (.Clock(Clock), .Reset(SW[0]), .randomNumber(fullCode));

	
	reg [1:0] digit3, digit2, digit1, digit0; 
	always @(fullCode) begin
		{digit3, digit2, digit1, digit0} = fullCode; 
	end 
	
	twobitreg setrandomVal3 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[1]), .D(digit3), .Q(code3)); //code[3:0] saved pin
	twobitreg setrandomVal2 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[1]), .D(digit2), .Q(code2));
	twobitreg setrandomVal1 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[1]), .D(digit1), .Q(code1));
	twobitreg setrandomVal0 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[1]), .D(digit0), .Q(code0));
	

	assign savedCode = {code3, code2, code1, code0}; 
	
	
	twobitreg setguessVal3 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[0]), .D(SW[9:8]), .Q(guess3)); //saved guess
	twobitreg setguessVal2 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[0]), .D(SW[7:6]), .Q(guess2));
	twobitreg setguessVal1 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[0]), .D(SW[5:4]), .Q(guess1));
	twobitreg setguessVal0 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[0]), .D(SW[3:2]), .Q(guess0));
//	
//	hexDisplayDecoder h3 (.Clock(Clock), .hexDigit(guess3), .hexDisplay(HEX5)); //outputs switch input
//	hexDisplayDecoder h2 (.Clock(Clock), .hexDigit(guess2), .hexDisplay(HEX4)); 
//	hexDisplayDecoder h1 (.Clock(Clock), .hexDigit(guess1), .hexDisplay(HEX3)); 
//	hexDisplayDecoder h0 (.Clock(Clock), .hexDigit(guess0), .hexDisplay(HEX2)); 
	
		
	hexDisplayDecoder h3 (.Clock(Clock), .hexDigit(code3), .hexDisplay(HEX5)); //outputs code
	hexDisplayDecoder h2 (.Clock(Clock), .hexDigit(code2), .hexDisplay(HEX4)); 
	hexDisplayDecoder h1 (.Clock(Clock), .hexDigit(code1), .hexDisplay(HEX3)); 
	hexDisplayDecoder h0 (.Clock(Clock), .hexDigit(code0), .hexDisplay(HEX2)); 
	
	
	compareGuess c3 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[0]), 
	.guess(guess3), .code(code3), .out(match_signal3));
	
	compareGuess c2 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[0]), 
	.guess(guess2), .code(code2), .out(match_signal2));
	
	compareGuess c1 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[0]), 
	.guess(guess1), .code(code1), .out(match_signal1));
	
	compareGuess c0 (.Clock(Clock), .Reset(SW[0]), .enable(~KEY[0]), 
	.guess(guess0), .code(code0), .out(match_signal0));	
	
	reg [1:0] countMatched;
	assign countMatched = match_signal3 + match_signal2 + match_signal1 + match_signal0;
	
	hexDisplayDecoder matchCount (.Clock(Clock), .hexDigit(countMatched), .hexDisplay(HEX1)); 
	
	reg [1:0] misplaceCount3, misplaceCount2, misplaceCount1, misplaceCount0; 
	
	determineMisplace m3 (.Clock(Clock), .Reset(SW[0]), .enable(~match_signal3), 
	.guess(guess3), .inputCode(savedCode), .out(misplaceCount3)); //match_signal should be false
	
	determineMisplace m2 (.Clock(Clock), .Reset(SW[0]), .enable(~match_signal2), 
	.guess(guess2), .inputCode(savedCode), .out(misplaceCount2)); //match_signal should be false
	
	determineMisplace m1 (.Clock(Clock), .Reset(SW[0]), .enable(~match_signal1), 
	.guess(guess1), .inputCode(savedCode), .out(misplaceCount1)); //match_signal should be false
	
	determineMisplace m0 (.Clock(Clock), .Reset(SW[0]), .enable(~match_signal0), 
	.guess(guess0), .inputCode(savedCode), .out(misplaceCount0)); //match_signal should be false
	
	reg [1:0] countMisplaced;
	assign countMisplaced = misplaceCount3 + misplaceCount2 + misplaceCount1 + misplaceCount0;
	
	hexDisplayDecoder misplaceCount (.Clock(Clock), .hexDigit(countMisplaced), .hexDisplay(HEX0)); 
	
	reg [3:0] matchingNumbers; 
	assign matchingNumbers = {match_signal3, match_signal2, match_signal1, match_signal0}; 
	
	checkWinner winCheck (.signals(matchingNumbers), .out(LED));
endmodule 

module mastermind_testbench();
	logic Clock;
	logic [1:0] KEY;
	logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX0; 
	logic [9:0] SW;
	
	mastermind dut (.Clock(Clock), .SW(SW[9:0]), .HEX5(HEX5[6:0]), .HEX4(HEX4[6:0]),
											.HEX3(HEX3[6:0]), .HEX2(HEX2[6:0]), .HEX0(HEX0[6:0]), .KEY(KEY[1:0]));
					
	
	parameter CLOCK_PERIOD = 100;
	
	initial Clock = 1;
	always begin
			#(CLOCK_PERIOD/2);
		Clock = ~Clock;
	end
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		SW[0] <= 1;		KEY[0] <= 0;	@(posedge Clock); //reset
										@(posedge Clock);
		SW[0] <= 0;					@(posedge Clock);
										@(posedge Clock);
		KEY[1] <= 1;	@(posedge Clock);		//making new randomValues
		KEY[1] <= 0;	@(posedge Clock);
		
		KEY[1] <= 1;	@(posedge Clock);
		KEY[1] <= 0;	@(posedge Clock);
		
		KEY[1] <= 1;	@(posedge Clock);		//making new randomValues
		KEY[1] <= 0;	@(posedge Clock);
		
		KEY[1] <= 1;	@(posedge Clock);
		KEY[1] <= 0;	@(posedge Clock);
		
		KEY[1] <= 1;	@(posedge Clock);		//making new randomValues
		KEY[1] <= 0;	@(posedge Clock);
		
		KEY[1] <= 1;	@(posedge Clock);
		KEY[1] <= 0;	@(posedge Clock);
		
		KEY[1] <= 1;	@(posedge Clock);		//making new randomValues
		KEY[1] <= 0;	@(posedge Clock);
		
		KEY[1] <= 1;	@(posedge Clock);
		KEY[1] <= 0;	@(posedge Clock);
		
		KEY[1] <= 1;	@(posedge Clock);		//making new randomValues
		KEY[1] <= 0;	@(posedge Clock);
		
		KEY[1] <= 1;	@(posedge Clock);
		KEY[1] <= 0;	@(posedge Clock);
		
		
		SW[9] <= 1; SW[8:2] <= 0; KEY[0] <= 1; @(posedge Clock);  // start inputting switch values, save them
		KEY <= 0;				@(posedge Clock);
		SW[8] <= 1;						KEY[0] <= 1; @(posedge Clock);
		KEY <= 0;				@(posedge Clock);
		SW[7] <= 1;						KEY[0] <= 1; @(posedge Clock);
		KEY <= 0;				@(posedge Clock);
		SW[6] <= 1;					@(posedge Clock); //skip save
										@(posedge Clock);
										@(posedge Clock);	
										@(posedge Clock);
		SW[5] <= 1;				KEY[0] <= 1;	@(posedge Clock); // change value, save again
		KEY <= 0;				@(posedge Clock);
		SW[4] <= 1;				KEY[0] <= 1;		@(posedge Clock);
		KEY <= 0;				@(posedge Clock);
		SW[3] <= 1;				KEY[0] <= 1;		@(posedge Clock);
		KEY <= 0;				@(posedge Clock);
		SW[2] <= 1;				KEY[0] <= 1;		@(posedge Clock);
		KEY <= 0;				@(posedge Clock);

		
		SW[0] <= 1;				@(posedge Clock);
		SW[0] <= 0;				@(posedge Clock); 
		$stop;
	end
endmodule	

module checkWinner (signals, out);
	input logic [3:0] signals;
	output logic out;
	
	always @(*) begin
		if(signals[3:0] == 4'b1111)
			out <= 1;
		else
			out <= 0;
	end
endmodule

module randomNumGenerator (Clock, Reset, randomNumber);
	input Clock, Reset;
	output logic [7:0] randomNumber;
	
	wire feedback;
	assign feedback = ~(randomNumber[7]^randomNumber[5]^randomNumber[4]^randomNumber[3]);
	
	always @(posedge Clock) 
		if(Reset) begin
			randomNumber <= 8'b0;
		end 
		else begin
			randomNumber <= {randomNumber[6], randomNumber[5],
									randomNumber[4], randomNumber[3],
									randomNumber[2], randomNumber[1],
									randomNumber[0], feedback};
		end
	
endmodule


module twobitreg (Clock, Reset, enable, D, Q); 
	input Clock, Reset, enable;
	input [1:0] D;
	output reg [1:0] Q;
	
	always @(posedge Clock) begin
		if(Reset == 0 && enable == 0) begin
			Q <= Q; 						// maintain the value
		end
		else if(enable == 1) begin 
			Q <= D; 						//store value of d in the register
		end
	end
endmodule

module determineMisplace(Clock, Reset, enable, guess, inputCode, out); 
	input Clock, Reset, enable;
	input [1:0] guess; 
	input [7:0] inputCode;
	
	output logic [1:0] out;
	
	always @(posedge Clock) begin
	if(enable)
		if(guess == inputCode[1:0])
			out <= 2'b01;
		else if(guess == inputCode[3:2])
			out <= 2'b01;
		else if(guess == inputCode[5:4])
			out <= 2'b01;
		else if(guess == inputCode[7:6])
			out <= 2'b01;
		else
			out <= 2'b00;
	else
		out <= 2'b00;
	end 
endmodule

module determineMisplace_testbench();
	logic Clock, Reset, enable;
	logic [1:0] guess; 
	logic [7:0] inputCode;
	logic [1:0] out;
	
	determineMisplace dut (.Clock(Clock), .Reset(Reset), .enable(enable), .guess(guess), .inputCode(inputCode), .out(out));
	
	parameter CLOCK_PERIOD = 100;
	
	initial Clock = 1;
	always begin
			#(CLOCK_PERIOD/2);
		Clock = ~Clock;
	end
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		Reset <= 1;	@(posedge Clock);
		Reset <= 0;	@(posedge Clock);
		
		guess <= 2'b00;	@(posedge Clock);
		inputCode <= 8'b00110101;	@(posedge Clock); 
		enable <= 1;				@(posedge Clock);
		enable <= 0; 		@(posedge Clock); 
		
		guess <= 2'b01;	@(posedge Clock);
		inputCode <= 8'b00110101;	@(posedge Clock); 
		enable <= 1;				@(posedge Clock);
		enable <= 0; 		@(posedge Clock); 
		
		guess <= 2'b10;	@(posedge Clock);  // no matches
		inputCode <= 8'b00110101;	@(posedge Clock); 
		enable <= 1;				@(posedge Clock);
		enable <= 0; 		@(posedge Clock); 
		
		guess <= 2'b11;	@(posedge Clock);
		inputCode <= 8'b00110101;	@(posedge Clock); 
		enable <= 1;				@(posedge Clock);
		enable <= 0; 		@(posedge Clock); 
		$stop;
	end
endmodule

module compareGuess(Clock, Reset, enable, guess, code, out);
	input Clock, enable, Reset;
	input [1:0] guess, code;
	output logic [1:0] out; 
	
	always @(*) begin
		if(guess == code && enable == 1)
			out = 2'b01;
		else if(Reset)
			out = 2'b00;
		else 
			out = 2'b00;
	end
endmodule
	
module hexDisplayDecoder(Clock, hexDigit, hexDisplay);
	input Clock;
	input [1:0] hexDigit;
	output logic [6:0] hexDisplay;
	
	parameter [6:0]	zero = 	7'b1000000,	//hex displays for counting (active low)
							one =  	7'b1111001,
							two =  	7'b0100100,
							three = 	7'b0110000;
	
	always @(*) begin
		case(hexDigit)
			2'b00: hexDisplay = zero;
			2'b01: hexDisplay = one;
			2'b10: hexDisplay = two;
			2'b11: hexDisplay = three; 
		endcase
	end
endmodule

module hexDisplayDecoder_testbench();
	logic [1:0] hexDigit;
	logic [6:0] hexDisplay;
	logic Clock;
	
	hexDisplayDecoder dut (.Clock(Clock), .hexDigit(hexDigit), .hexDisplay(hexDisplay));
	
	parameter CLOCK_PERIOD = 100;
	
	initial Clock = 1;
	always begin
			#(CLOCK_PERIOD/2);
		Clock = ~Clock;
	end
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		hexDigit <= 2'b00;	@(posedge Clock);
		hexDigit <= 2'b01;	@(posedge Clock);
		hexDigit <= 2'b10;	@(posedge Clock);
		hexDigit <= 2'b11;	@(posedge Clock);
		$stop;
	end
endmodule	

	
module twobitreg_testbench();
	logic Clock, Reset, enable;
	logic [1:0] inputValue, storedValue;
	
	twobitreg dut (.Clock(Clock), .Reset(Reset), .enable(enable),
											.D(inputValue), .Q(storedValue));
																
									
	parameter CLOCK_PERIOD = 100;
	
	initial Clock = 1;
	always begin
			#(CLOCK_PERIOD/2);
		Clock = ~Clock;
	end
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
	
		Reset <= 1;	@(posedge Clock);
		Reset	<= 0;		@(posedge Clock);
		inputValue <= 2'b00; enable <= 1; @(posedge Clock);
		enable <= 0;							@(posedge Clock);
		inputValue <= 2'b01;	@(posedge Clock);
		enable <= 1;	@(posedge Clock);
		enable <=0;								@(posedge Clock);
		 inputValue <= 2'b11;				@(posedge Clock);
		enable <= 1;								@(posedge Clock);
		enable <= 0;											@(posedge Clock);
		Reset <= 1;	@(posedge Clock);
													@(posedge Clock);
		Reset <= 0;		@(posedge Clock); 
	
		$stop;
	end
endmodule	
		
module randomNumberGenerator_testbench();
	logic Clock, Reset;
	logic [7:0] randomNumber;
	
	
	randomNumGenerator dut (.Clock(Clock), .Reset(Reset),
										.randomNumber(randomNumber));
										
//	logic [1:0] digit3, digit2, digit1, digit0; 
//	always @(randomNumber) begin
//		{digit3, digit2, digit1, digit0} = randomNumber; 
//	end 
//	
	parameter CLOCK_PERIOD = 100;
	
	initial Clock = 1;
	always begin
			#(CLOCK_PERIOD/2);
		Clock = ~Clock;
	end
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
	
		Reset <= 1;			@(posedge Clock);
		Reset	<= 0;			@(posedge Clock);
								@(posedge Clock);
								@(posedge Clock);
								@(posedge Clock);
								@(posedge Clock);
								@(posedge Clock);
								@(posedge Clock);				
								@(posedge Clock);
								@(posedge Clock);
		Reset	<= 0;			@(posedge Clock);
	
		$stop;
	end
endmodule
