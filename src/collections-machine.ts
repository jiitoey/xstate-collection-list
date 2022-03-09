import { assign, createMachine } from "xstate";

interface Context {
  totalCollections: number;
  collections: {
    name: string;
    artistName: string;
    totalItems: number;
    previewImgs: string[];
    chainIconImg: string;
  }[];
}
const mockFetchCollectionsResult = async () => {
  const totalCollections = 10;
  const nList = [...Array(10).keys()];
  const collections = nList.map((n) => {
    return {
      name: `collection-${n}`,
      artistName: `John Doe the ${n}`,
      totalItems: 123456,
      previewImgs: [
        "https://source.unsplash.com/random/100x100",
        "https://source.unsplash.com/random/100x100",
        "https://source.unsplash.com/random/100x100",
      ],
      chainIconImg: "https://source.unsplash.com/random/20x20",
    };
  });
  if (Math.floor(Math.random() * 100) < 30) throw "Forced fetch items ERROR";
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve({ totalCollections, collections });
    }, 500);
  }) as Promise<{
    totalCollections: number;
    collections: {
      name: string;
      artistName: string;
      totalItems: number;
      previewImgs: string[];
      chainIconImg: string;
    }[];
  }>;
};

export const itemsMachine = createMachine(
  {
    tsTypes: {} as import("./collections-machine.typegen").Typegen0,
    id: "COLLECTIONS",
    schema: {
      context: {} as Context,
      events: {} as { type: "COLLECTIONS.RELOAD" },
      services: {} as {
        fetchCollections: {
          data: {
            totalCollections: number;
            collections: {
              name: string;
              artistName: string;
              totalItems: number;
              previewImgs: string[];
              chainIconImg: string;
            }[];
          };
        };
      },
    },
    context: {
      totalCollections: 0,
      collections: [],
    },
    states: {
      loading: {
        invoke: {
          id: "fetch-collections",
          src: "fetchCollections",
          onDone: {
            target: "display",
            actions: "updateCollections",
          },
          onError: { target: "failed" },
        },
      },
      display: {
        on: {
          "COLLECTIONS.RELOAD": {
            target: "loading",
          },
        },
      },
      failed: {
        on: {
          "COLLECTIONS.RELOAD": {
            target: "loading",
          },
        },
      },
    },
    initial: "loading",
  },
  {
    services: {
      fetchCollections: async (context) => {
        // const response = await fetch(`https://www.bgf.com/`);
        // const json = await response.json();
        const json = await mockFetchCollectionsResult();
        return json;
      },
    },
    actions: {
      updateCollections: assign((context, event) => {
        return {
          ...context,
          collections: event.data.collections,
          totalCollections: event.data.totalCollections,
        };
      }),
    },
  }
);
