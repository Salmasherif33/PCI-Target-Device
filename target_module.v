//clock generator
module Clock(clock);
output reg clock;
initial
clock = 1;
always 
#5 clock = ~clock;
endmodule
//target device
module targetll (clk,reset,FRAME,AD,DEVSEL,C_BE,IRDY,TRDY,rw,ntrdy);
input clk,reset,FRAME,IRDY,rw,ntrdy; 
input [3:0] C_BE; 
output reg TRDY=1,DEVSEL=1;
inout [31:0] AD; //multiplexed adress and data lines
reg [31:0] memory [0:2]; //memory to store data
reg [31:0] buffer [0:2]; //buffer 
//reg frame, irdy, trdy , devsel; //signals to assign in it values of signals
reg [3:0] c_be; //reg to store control lines in it
reg [3:0] BE; //byte enable
reg [31:0] ad = 32'hzzzzzzzz; //reg to store the data on the data line in it
reg [31:0] devAddr;
reg [2:0] state, prev_state;
reg [2:0] mp; //pointer to the memory

assign AD = (!rw)? ad:32'hzzzzzzzz;
// define the state
parameter idle = 3'b000,
device_select = 3'b010, read_state = 3'b011, write_state = 3'b100,target_scenario=3'b001,
buffer_state = 3'b101, waiting = 3'b111 ;

//check the signals to move to the right state
always @ (posedge clk or reset) begin 
if(reset) begin
state <= idle;
end 
//send the address to begin the transaction

else if(!FRAME&&IRDY==1 &&(AD==0 || AD==1 || AD==2) && prev_state == idle) begin
state=device_select;
devAddr <= AD;
mp <= AD;
c_be = C_BE;
end

//begin the transaction (data 1)
else if(!FRAME && DEVSEL==0&&TRDY==0&&c_be==4'b0111&&IRDY==0 && prev_state == device_select) begin
state<=write_state;
ad <=AD;
BE <= C_BE;
end

//begin reading data1
else if(!FRAME && DEVSEL==0&&TRDY==1&&c_be==4'b0110&&IRDY==0 && prev_state == device_select && !rw &&ntrdy==0)begin
state <=read_state;
end
//read data 2
else if(!FRAME && DEVSEL==0&&TRDY==0&& IRDY == 0 && c_be==4'b0110&& prev_state == read_state||prev_state==waiting && !rw)begin///
state <=read_state;
end

//irdy not ready in read
else if(!FRAME && DEVSEL==0&&TRDY==0&& IRDY == 1 && c_be==4'b0110&& prev_state == read_state && !rw)begin
state <=waiting;

end
//continue transaction (not the last data or the first data)
else if(!FRAME && DEVSEL==0&&TRDY==0&&c_be==4'b0111&&IRDY==0 && prev_state == write_state||prev_state==waiting ||
 prev_state== buffer_state) begin
state<=write_state;
ad <=AD;
BE <= C_BE;
end
else if (!FRAME && IRDY && !TRDY &&!DEVSEL&& rw)begin
state <= waiting;
end 
//the last transaction (data 3)
else if(FRAME && !IRDY &&!TRDY &&!DEVSEL&& prev_state == write_state||prev_state==waiting || prev_state== buffer_state)begin///
state<=write_state;
ad <=AD;
BE <= C_BE;
end
//if the targeT not READY
else if(!IRDY &&TRDY &&!DEVSEL&& prev_state == write_state)begin
state <= buffer_state;
ad<=AD;
BE <= C_BE;
end

//the last transaction in read 
else if (FRAME && !IRDY && prev_state == read_state)begin
state <= read_state;
end
//end the transaction
else if (FRAME && IRDY && (prev_state == write_state || prev_state == read_state))begin
state <=idle;
ad <= 32'hzzzzzzzz;
end
//target_scenario

else if(!FRAME && DEVSEL==0&&TRDY==1&&c_be==4'b0110&&IRDY==0 && prev_state == device_select && ntrdy)begin
state <=target_scenario;
end

else if(!FRAME && DEVSEL==0&&c_be==4'b0110&&IRDY==0 &&TRDY == 0 && prev_state == target_scenario && ntrdy)begin
state <=target_scenario;
end

else if(!FRAME && DEVSEL==0&&c_be==4'b0110&&IRDY==0 &&TRDY ==1&& prev_state == target_scenario && ntrdy)begin
mp = mp -1;
state =target_scenario;

end

else if (prev_state == target_scenario&&mp==3'b101)begin
state <=idle;
ad <= 32'hzzzzzzzz;

end

end

//write the signals and store the data
always @(negedge clk) begin

case(state)

//no transaction
idle: begin
TRDY <= 1'b1;
DEVSEL <= 1'b1;
mp <= 3'b000;
//ad <= 32'hzzzzzzzz;
end

//the right selected device
device_select: begin
DEVSEL<=0;
if(c_be == 4'b0111)begin
TRDY<=0;
end
end
//write data
write_state: begin
//write in memory but based on the byte enable bit
 if(BE[0] == 1'b1)begin
	memory[mp][7:0] = ad[7:0];
end
if(BE[1] == 1'b1)begin
	memory[mp][15:8] = ad[15:8];
end
if(BE[2] == 1'b1)begin
	memory[mp][23:16] = ad[23:16];
end
if(BE[3] == 1'b1)begin
	memory[mp][31:24] = ad[31:24];
end
mp = mp + 3'b001;

//to check if it is the last transaction or if the memory of target is full 
if(mp == 3'b011 && devAddr == 0)begin
TRDY <= 1'b1;
end
if(FRAME)begin
TRDY <= 1;
DEVSEL<= 1'b1;
end
if(mp == 3'b011 && devAddr != 0)begin
mp = 0;
end
end
//buffer when overflow
buffer_state:begin
mp = 0;
buffer[0] = memory[0];
buffer[1] = memory[1];
buffer[2] = memory[2];
TRDY = 0;

end

// read state
read_state: begin
TRDY = 0;
ad = memory[mp];
mp = mp + 3'b001;
// end of transaction or target finished reading
if(FRAME || mp == 3'b100)begin
TRDY <= 1'b1;
DEVSEL <= 1'b1;
end
end

// added target scenario
target_scenario:begin
if( mp != 1 || (mp == 1 && TRDY == 1))begin
ad = memory[mp];
TRDY = 0;
end


else if((mp)==1 && TRDY == 0)begin
TRDY = 1;
end

if(FRAME||mp == 3'b100)begin
TRDY <= 1'b1;
DEVSEL <= 1'b1;
mp = mp + 3'b001;
end

mp = mp + 3'b001;
end
waiting:begin
/*if (rw==1) begin
state = write_state;
end
else if(rw==0)
begin
state=read_state;
end*/
end
endcase
prev_state = state;
end
endmodule 
