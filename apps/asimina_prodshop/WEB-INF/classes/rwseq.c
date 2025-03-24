#include <stdio.h>

main(int n , char **arg)
{ unsigned a;
  register unsigned u = 0;
  unsigned char b[4] = {0};

  if( n == 1 ) {
  read(0,&a,1); u = (a & 255)  << 24;
  read(0,&a,1); u |= (a & 255) << 16;
  read(0,&a,1); u |= (a & 255) << 8;
  read(0,&a,1); u |= (a & 255);
  printf("%u\n",u) ;
  return(0);
  }

  if( *arg[1] == '-' )
   { printf( "usage rwseq < fichier_sequence pour lire\n"
              "rwseq nombre >fichier_sequence pour ecrire\n");
     return(0);
   }

  u = atoi( arg[1] );
  b[3] = u & 255; u >>= 8;
  b[2] |= u & 255; u >>= 8;
  b[1] |= u & 255; u >>= 8;
  b[0] |= u ;

  printf("%c%c%c%c",b[0],b[1],b[2],b[3]);
  

}
