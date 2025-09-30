module comparator(
	input A,
	input B,
	output reg smaller,
	output reg equal,
	output reg larger
);

always @(*) begin
	smaller = 1'b0;
	equal = 1'b0;
	larger = 1'b0;
	
	if (A>B)begin
	larger = 1'b1;
	smaller = 1'b0;
	equal = 1'b0;
	end
	else if (A==B)begin
	smaller = 1'b0;
	equal = 1'b1;
	larger = 1'b0;
	end
	else begin
	smaller = 1'b1;
	equal = 1'b0;
	larger = 1'b0;
	end
end

endmodule
