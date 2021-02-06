
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
  char* l_puc_UartPtr = UART_BASE_ADDRESS;
  c=a+b;
  PrintAscii("toto", 4);
  if (1) {
    PrintAscii("la question est vite repondue", 29);
  } else {
    PrintAscii("tu hors de ma vue!!", 19);
  }
  PrintInt(1234);
  PrintShort(4321);


  return 1;
}
