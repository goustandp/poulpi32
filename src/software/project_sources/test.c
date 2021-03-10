
#define UART_BASE_ADDRESS 0x1000

void PrintAscii(char* p_pc_Buff, unsigned int p_ul_BuffLength) {
  char* l_puc_UartPtr = UART_BASE_ADDRESS;
  for (unsigned int i = 0; i< p_ul_BuffLength; i++) {
    *l_puc_UartPtr = p_pc_Buff[i];
  }
  *l_puc_UartPtr = 0;
  
}

void PrintInt(int p_l_Int) {
  int* l_pl_UartPtr = UART_BASE_ADDRESS;
  *l_pl_UartPtr = p_l_Int;
}


void PrintShort(short p_s_Short) {
  short* l_ps_UartPtr = UART_BASE_ADDRESS;
  *l_ps_UartPtr = p_s_Short;
}


int main(void) {
  int a;
  int b;
  int c;
  a = 1234;
  b = 5678;
  c = a << 2;
  //test sum
  PrintAscii("test 1", 6);
  c = a+b;
  PrintInt(c);
  //test shift left
  PrintAscii("test 2", 6);
  c = a << 2;
  PrintInt(c);
  // test shift right
  PrintAscii("test 3", 6);
  c = a >> 2;
  PrintInt(c);
  // test less than
  PrintAscii("test 4", 6);
  if (a<b) {
    PrintAscii("OK", 2);
  }
  else {
    PrintAscii("KO", 2);
  }
  // test less or equal
  PrintAscii("test 5", 6);
  if (a<=b) {
    PrintAscii("OK", 2);
  } else {
    PrintAscii("KO", 2);
  }
  
  //test not
  PrintAscii("test 6", 6);
  c = ~a;
  PrintInt(c); 
  
  // test substract
  PrintAscii("test 7", 6);
  c = a-b;
  PrintInt(c); 
  c = b - 1234;
  PrintInt(c); 

  return 1;
}
