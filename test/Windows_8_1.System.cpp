#include <winrt/Windows.System.h>
#include <iostream>
#include <cassert>

enum class winrt::Windows::System::DispatcherQueuePriority : int32_t
{
  _unset,

  Low    = -13,
  Normal =  42,
  High   = +69,
};

struct winrt::Windows::System::DispatcherQueue
{
  mutable DispatcherQueuePriority test_val{};

  template<typename F>
  bool TryEnqueue( DispatcherQueuePriority const p, F && ) const
  {
    std::cout << static_cast<int32_t>(p) << '\n';
    test_val = p;
    return true;
  }
};

int main()
{
  using D = winrt::Windows::System::DispatcherQueue;
  using P = winrt::Windows::System::DispatcherQueuePriority;

  {
    const D d;
    winrt::resume_foreground( d ).await_suspend({});
    assert( d.test_val == P::Normal );
  }
  {
    const D d;
    winrt::resume_foreground( d, P::Low ).await_suspend({});
    assert( d.test_val == P::Low );
  }
  {
    const D d;
    winrt::resume_foreground( d, P::High ).await_suspend({});
    assert( d.test_val == P::High );
  }

#ifdef WINRT_IMPL_COROUTINES
  // TODO: test `operator co_await( Windows::System::DispatcherQueue const & )`
#endif
}
