// Copyright 2023 MERL-DSU

//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at

//        http://www.apache.org/licenses/LICENSE-2.0

//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

module Sign_Extend (In,ImmSrc,Imm_Ext);
    input [31:0] In;
    input [1:0] ImmSrc;
    output [31:0] Imm_Ext;
    /*
    assign Imm_Ext =  (ImmSrc == 2'b00) ? {{20{In[31]}},In[31:20]} : 
                     (ImmSrc == 2'b01) ? {{20{In[31]}},In[31:25],In[11:7]} : 32'h00000000;
    */
    assign Imm_Ext =  (ImmSrc == 2'b00) ?                  //I-Type
                        {{20{In[31]}},In[31:20]} :

                      (ImmSrc == 2'b01) ?                  //S-Type
                        {{20{In[31]}},In[31:25],In[11:7]} :

                      (ImmSrc == 2'b10) ?                  //B-type
                        {{19{In[31]}},
                          In[31],
                          In[7],
                          In[30:25],
                          In[11:8],
                          1'b0} :

                      (ImmSrc == 2'b11) ?                  //J-type
                        {{11{In[31]}},
                          In[31],
                          In[19:12],
                          In[20],
                          In[30:21],
                          1'b0} :

                        32'h00000000;
endmodule