
#include HEADER
#include <cstdio>

#define stringify_impl(x) #x
#define stringify(x) stringify_impl(x)

int main()
{
  std::puts( "It's-a me, " stringify(HEADER) "!" );
}
