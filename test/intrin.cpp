#include <winrt/yolort_impl/yolo.ipp>
#include <array>
#include <cassert>

int main()
{
  alignas(16) std::array<std::int64_t, 2> current{0,0};
  constexpr decltype(current)
    desired{ 0x0123456789ABCDEFll, -0x0123456789ABCDEFll };

  auto expected = current;
  assert(( _InterlockedCompareExchange128(
    current.data(), desired[1], desired[0], expected.data() ) ));
  assert( current == desired );
}
