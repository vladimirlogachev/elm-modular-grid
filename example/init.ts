// @ts-ignore
import { Elm } from "./.elm-land/src/Main.elm";

(async () => {
  const rootNode = document.querySelector("#app") as HTMLDivElement;

  Elm.Main.init({
    flags: {
      windowSize: {
        height: window.innerHeight,
        width: window.innerWidth,
      },
    },
    node: rootNode,
  });
})().catch((err) => console.error(err));
