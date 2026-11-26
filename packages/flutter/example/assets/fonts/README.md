# Inter, Latin subset

Inter v4.1 at weights 400 and 600, subset to Latin (`U+0000-00FF` and the common punctuation and symbol ranges), about 130 KB for the two.

The gallery ships a font of its own for two reasons, both measured on a web build:

- Without one, every Flutter preview on the documentation site fetched Roboto from `fonts.gstatic.com`, a request to a third party from every reader's browser.
- The engine's own Roboto has one face, and Flutter thickens it for every other weight, so a label at 600 came out smeared rather than semibold.

Inter has a real 600, and of the open families it is the nearest to the `system-ui` the React previews are drawn in. The demos are written in English; a character outside the subset falls back to the engine's font.

These files are the same subset the `plass-ui` gallery ships. Inter is © The Inter Project Authors (https://github.com/rsms/inter), licensed under the SIL Open Font License 1.1, which is in `OFL.txt` and travels with the files.
