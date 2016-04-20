module HCSR04(clk, reset, get, echo, trigger, data, ready);

parameter unsigned inputClk 	= 2000000;	//входная частота 
localparam  length 	= 100000; 				//1/100000 = 10 uS

input wire clk;									//входная частота 2МГц 
input wire reset;									//сборс устройства
input wire get;									//получить расстояние
input wire echo;									//отраженный импульс
output reg trigger;								//импульс запуска 0.1us
output reg [15:0] data;							//длительность отраженного имульса
output reg ready;									//импульс запуска Говтовности данных

reg [2:0] state;
reg lastEcho = 0;

localparam STATE_IDLE 	= 0;				//ожидание
localparam STATE_GET		= 1; 				//получить расстояние
localparam STATE_ECHO 	= 2; 				//подсчет длительности отраженного импульса
localparam STATE_FINISH = 3; 				//окончание процесса

always@(posedge clk)
begin
	if  (!reset)
		begin
			state 	<= STATE_IDLE;			
			data		<= 16'd0;
			trigger	<=	1'd0;
			ready		<=	1'd0;
			lastEcho <= 0;
		end
	else
		begin
			case (state)
				STATE_IDLE: begin
					if (!get)
						begin
							state <= STATE_GET;
							data <= 16'd0;
						end
					else
						state <= STATE_IDLE;
					trigger	<=	1'd0;
					ready		<=	1'd0;
					lastEcho <= 0;
				end
				STATE_GET: begin
					if (data == ((inputClk/length)-1))
						begin
							state <= STATE_ECHO;
							data		<= 16'd0;				
						end
					else
						begin
							state <= STATE_GET;
							data		<= data + 16'd1;				
						end
					trigger	<=	1'd1;
					ready		<=	1'd0;
					lastEcho <= 0;
				end
				STATE_ECHO: begin
					case ({lastEcho,echo})
						0 :	begin
									state <= STATE_ECHO;
								end
						1 :	begin
									lastEcho <= echo;
									data		<= data + 16'd1;
									state <= STATE_ECHO;
								end
						2 :	begin
									state <= STATE_FINISH;
								end
						3 :	begin
									data		<= data + 16'd1;
									state <= STATE_ECHO;
								end
					endcase
					trigger	<=	1'd0;
					ready		<=	1'd0;
				end
				STATE_FINISH: begin				
					state <= STATE_IDLE;
					trigger	<=	1'd0;
					ready		<=	1'd1;
					lastEcho <= 0;	
				end
			endcase
		end
end


endmodule