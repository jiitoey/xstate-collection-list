// This file was automatically generated. Edits will be overwritten

export interface Typegen0 {
  "@@xstate/typegen": true;
  eventsCausingActions: {
    updateCollections: "done.invoke.fetch-collections";
  };
  internalEvents: {
    "done.invoke.fetch-collections": {
      type: "done.invoke.fetch-collections";
      data: unknown;
      __tip: "See the XState TS docs to learn how to strongly type this.";
    };
    "xstate.init": { type: "xstate.init" };
    "error.platform.fetch-collections": {
      type: "error.platform.fetch-collections";
      data: unknown;
    };
  };
  invokeSrcNameMap: {
    fetchCollections: "done.invoke.fetch-collections";
  };
  missingImplementations: {
    actions: never;
    services: never;
    guards: never;
    delays: never;
  };
  eventsCausingServices: {
    fetchCollections: "COLLECTIONS.RELOAD";
  };
  eventsCausingGuards: {};
  eventsCausingDelays: {};
  matchesStates: "loading" | "display" | "failed";
  tags: never;
}
