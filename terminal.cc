#include "terminal.hh"

// ostream& endl(ostream& os)
//       {  os << '\n';
//          os.flush();
//          return os;
//       }

std::ostream& fg::red(std::ostream& os) { return os << RED; }

std::ostream& reset(std::ostream& os) { return os << RESET; }
