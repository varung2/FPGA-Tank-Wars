//
// Sine Wave ROM Table
//
module sine_table(
  input [7:0] index,
  output [15:0] signal
);
parameter PERIOD = 48; // length of table

assign signal = sine;
reg [15:0] sine;
        
always@(index)
begin
case(index)
0  :  sine       <=      0       ;
1  :  sine       <=      4276    ;
2  :  sine       <=      8480    ;
3  :  sine       <=      12539   ;
4  :  sine       <=      16383   ;
5  :  sine       <=      19947   ;
6  :  sine       <=      23169   ;
7  :  sine       <=      25995   ;
8  :  sine       <=      28377   ;
9  :  sine       <=      30272   ;
10  :  sine      <=      31650   ;
11  :  sine      <=      32486   ;
12  :  sine      <=      32767   ;
13  :  sine      <=      32486   ;
14  :  sine      <=      31650   ;
15  :  sine      <=      30272   ;
16  :  sine      <=      28377   ;
17  :  sine      <=      25995   ;
18  :  sine      <=      23169   ;
19  :  sine      <=      19947   ;
20  :  sine      <=      16383   ;
21  :  sine      <=      12539   ;
22  :  sine      <=      8480    ;
23  :  sine      <=      4276    ;
24  :  sine      <=      0       ;
25  :  sine      <=      61259   ;
26  :  sine      <=      57056   ;
27  :  sine      <=      52997   ;
28  :  sine      <=      49153   ;
29  :  sine      <=      45589   ;
30  :  sine      <=      42366   ;
31  :  sine      <=      39540   ;
32  :  sine      <=      37159   ;
33  :  sine      <=      35263   ;
34  :  sine      <=      33885   ;
35  :  sine      <=      33049   ;
36  :  sine      <=      32768   ;
37  :  sine      <=      33049   ;
38  :  sine      <=      33885   ;
39  :  sine      <=      35263   ;
40  :  sine      <=      37159   ;
41  :  sine      <=      39540   ;
42  :  sine      <=      42366   ;
43  :  sine      <=      45589   ;
44  :  sine      <=      49152   ;
45  :  sine      <=      52997   ;
46  :  sine      <=      57056   ;
47  :  sine      <=      61259   ;
default   : sine   <=   0   ;
endcase
end
endmodule
