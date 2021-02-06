
#include <winrt/yolort_impl/yolo.ipp>
#include <cassert>

int main()
{
	assert( _ReturnAddress() != nullptr );
	assert( _ReturnAddress() == __builtin_return_address(0) );
}
