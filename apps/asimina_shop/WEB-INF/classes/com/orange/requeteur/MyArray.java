package com.orange.requeteur;

/**
* Simple String Array Dynamique permettant les trous.
*/

public class MyArray {

class Link {
int id;
String val;
Link next;
}

Link lk = null;
int max = -1;
int count=0;

public void set( int i , String s)
{
  if( count == 0 )
    { lk = new Link();
      lk.id = i;
      lk.val = s;
      count++;
      max = i;
      return;
    }

  Link t,r ;
  r = t = lk;
  while( r != null )
   { if( r.id == i )
      { r.val = s;
        return;
      }
     t = r;
     r = t.next;
   }

  t.next = r = new Link();
  r.id = i;
  r.val = s;
  count++;
  if( i > max ) max = i;
}



public String get( int i )
{ if( count == 0 ) return(null);
  Link r = lk;
  while( r != null )
  {
   if( r.id == i ) return( r.val);
   r = r.next;
  }
 return(null);
}

void refresh()
{
  if( count == 0 )
    return;
  Link r = lk;
  int max = -1 ;
  while( r != null )
  {  if( r.id > max ) max = r.id ;
     r = r.next;
  }
}

public String remove( int i )
{
  String val;
  Link t,r ;
  r = t = lk;
  while( r != null )
   { if( r.id == i )
      { val = r.val ;
        t.next = r.next;
        r.val = null; r = null;
        count--;
        refresh();
        return(val);
      }
     t = r;
     r = t.next;
   }

  return(null);

}

public int count() { return( count); }
public int max() { return( max); }
public int next( int i )
{
  if( count == 0 ) return(-1);
  Link r = lk;
  while( r != null )
  {
   if( r.id == i )
     return( r.next==null?-1:r.next.id );
   r = r.next;
  }
 return(-1);
}


}




