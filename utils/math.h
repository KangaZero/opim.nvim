
// Source - https://stackoverflow.com/a/3437484
// Posted by David Titarenco, modified by community. See post 'Timeline' for
// change history Retrieved 2026-04-15, License - CC BY-SA 4.0
#define max(a, b)                                                              \
  ({                                                                           \
    __typeof__(a) _a = (a);                                                    \
    __typeof__(b) _b = (b);                                                    \
    _a > _b ? _a : _b;                                                         \
  })

#define min(a, b)                                                              \
  ({                                                                           \
    __typeof__(a) _a = (a);                                                    \
    __typeof__(b) _b = (b);                                                    \
    _a > _b ? _b : _a;                                                         \
  })

#define clamp(num, min, max)                                                   \
  ({                                                                           \
    __typeof__(min) _min = (min);                                              \
    __typeof__(max) _max = (max);                                              \
    __typeof__(num) _num = (num);                                              \
    _num > _max ? _max : _num < _min ? _min : _num;                            \
  })
