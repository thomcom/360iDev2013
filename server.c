/* A simple server in the internet domain using TCP
   The port number is passed as an argument */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>

uint8_t solveSimple(char* buffer, uint8_t length, int *result){
    if( length < 3 ){
        return 0;
    }
    int a = atoi(&buffer[0]);
    int b = atoi(&buffer[2]);
    switch (buffer[1]) {
        case '+':
            *result = a+b;
            break;
        case '/':
            *result = a/b;
            break;
        case '-':
            *result = a-b;
            break;
        case '*':
            *result = a*b;
            break;
        default:
            return 0;
    }
    return 1;
}

int main(int argc, char *argv[])
{
   // c-style predeclarations
   int sockfd, newsockfd, portno;
   socklen_t clilen;
   char buffer[256];
   struct sockaddr_in serv_addr, cli_addr;
   int n;

   // check that port was provided at command line
   if (argc < 2) {
      fprintf(stderr,"ERROR, no port provided\n");
      return -1;
   }

   // create a socket for TCP/IP streaming.
   sockfd = socket(AF_INET, SOCK_STREAM, 0);
   if (sockfd < 0) {
     printf("ERROR opening socket");
     return -1;
   }

   // boilerplate C code to create a sockaddr_in struct
   bzero((char *) &serv_addr, sizeof(serv_addr));
   portno = atoi(argv[1]);
   serv_addr.sin_family = AF_INET;
   serv_addr.sin_addr.s_addr = INADDR_ANY;
   serv_addr.sin_port = htons(portno);

   // connect the socket to the OS and open it to the outside world
   if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
      printf("ERROR on binding");
      return -1;
   }
   listen(sockfd,5);
   while(1){
      clilen = sizeof(cli_addr);
      // blocks indefinitely, duplicating sockfd and placing it on a 
      newsockfd = accept(sockfd,
                        (struct sockaddr *) &cli_addr,
                        &clilen);
      if (newsockfd < 0){
         printf("ERROR on accept");
         return -1;
      }
      bzero(buffer,256);
      // block and read up to 255 bytes from OS socket API
      n = read(newsockfd,buffer,255);
      if (n < 0){
         printf("ERROR reading from socket");
         return -1;
      }
      // kill command from client
      if(buffer[0]=='-' && buffer[1]=='1'){
         break;
      }

      printf("Read: %s",buffer); 
      int result = 0;
      uint8_t success = solveSimple(buffer,255,&result);
      char msg[20];
      if( success ){
         sprintf(msg,"%d\r\n\r\n",result);
      }
      else{
         sprintf(msg,"No answer!\r\n\r\n");
      }
      int i = 0;
      for( i = 0 ; i < 1 ; ++i){
         n = write(newsockfd,msg,18);
         if (n < 0){
            printf("ERROR writing to socket");
            return -1;
         }
         usleep(100000);
      }
      close(newsockfd);
   }
   close(sockfd);
   return 0; 
}
