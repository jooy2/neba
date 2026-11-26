# Sample media

The pictures the gallery's demos draw on, so a demo that holds a photograph holds a real one rather than a drawn stand-in. Each file is a byte-for-byte copy of the file at the same path under `docs/public/samples/` in the repository, which is where the React previews take theirs from; `test/samples_test.dart` fails when the two differ. Only the files a ported demo uses are copied.

They are resized copies of assets from [sample-assets](https://github.com/jooy2/sample-assets), which is MIT licensed:

> MIT License
>
> Copyright (c) 2026 CDGet (https://cdget.com).
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
