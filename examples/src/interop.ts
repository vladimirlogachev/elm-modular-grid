export const flags = ({ env }) => {
  return {
    windowSize: {
      height: window.innerHeight,
      width: window.innerWidth,
    },
  };
};

export const onReady = ({ app, env }) => {
  app.ports.urlChanged.subscribe((val) => {
    window.scrollTo(0, 0);
  });
}

