#pragma once

#include <memory>
#include <phoenix/display/native/NativeView.hpp>

namespace phoenix::display {

class Display;
using Display_ptr = std::shared_ptr<Display>;

class Display final {
public:
  NativeView_ptr getDisplayView();
  static Display_ptr instance();
  static void reset();
};

} // namespace phoenix::display
