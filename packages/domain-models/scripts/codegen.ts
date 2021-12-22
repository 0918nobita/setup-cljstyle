import { genCode } from '@setup-cljstyle/codegen';
import fs from 'fs';
import path from 'path';

const dest = path.join(__dirname, '..', 'generated');

fs.mkdirSync(dest, { recursive: true });

genCode(path.join(dest, 'index.ts'), [
    'DirPath',
    'FilePath',
    'Url',
    'Version',
    'InputName',
    'InputValue',
]);
