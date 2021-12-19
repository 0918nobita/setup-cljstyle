import { build } from "esbuild";

import { baseBuildOptions } from "./base";

build({ ...baseBuildOptions, watch: true })
    .then((res) => {
        console.log(res);
    })
    .catch((e) => {
        console.error(e);
    });
