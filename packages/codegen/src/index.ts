import { writeFileSync } from 'fs';
import * as ts from 'typescript';

const strType = ts.factory.createKeywordTypeNode(ts.SyntaxKind.StringKeyword);

const exportKeyword = ts.factory.createModifier(ts.SyntaxKind.ExportKeyword);

const uniqueSymbol = ts.factory.createTypeOperatorNode(
    ts.SyntaxKind.UniqueKeyword,
    ts.factory.createKeywordTypeNode(ts.SyntaxKind.SymbolKeyword)
);

const brandedTypeDecl = (name: string) =>
    ts.factory.createTypeAliasDeclaration(
        [],
        [exportKeyword],
        name,
        [],
        ts.factory.createIntersectionTypeNode([
            strType,
            ts.factory.createTypeLiteralNode([
                ts.factory.createPropertySignature(
                    [ts.factory.createModifier(ts.SyntaxKind.ReadonlyKeyword)],
                    ts.factory.createIdentifier('__brand'),
                    void 0,
                    uniqueSymbol
                ),
            ]),
        ])
    );

const equalsGreaterThanToken = ts.factory.createToken(
    ts.SyntaxKind.EqualsGreaterThanToken
);

const exportConstStmt = (varDecl: ts.VariableDeclaration) =>
    ts.factory.createVariableStatement(
        [exportKeyword],
        ts.factory.createVariableDeclarationList([varDecl], ts.NodeFlags.Const)
    );

const simpleVarDecl = (name: string, initializer: ts.Expression) =>
    ts.factory.createVariableDeclaration(name, void 0, void 0, initializer);

const wrapFuncDef = (name: string) =>
    exportConstStmt(
        simpleVarDecl(
            `wrap${name}`,
            ts.factory.createArrowFunction(
                [],
                [],
                [
                    ts.factory.createParameterDeclaration(
                        [],
                        [],
                        void 0,
                        's',
                        void 0,
                        strType
                    ),
                ],
                void 0,
                equalsGreaterThanToken,
                ts.factory.createAsExpression(
                    ts.factory.createIdentifier('s'),
                    ts.factory.createTypeReferenceNode(name)
                )
            )
        )
    );

const unwrapFuncDef = (name: string) =>
    exportConstStmt(
        simpleVarDecl(
            `unwrap${name}`,
            ts.factory.createArrowFunction(
                [],
                [],
                [
                    ts.factory.createParameterDeclaration(
                        [],
                        [],
                        void 0,
                        'a',
                        void 0,
                        ts.factory.createTypeReferenceNode(name)
                    ),
                ],
                strType,
                equalsGreaterThanToken,
                ts.factory.createIdentifier('a')
            )
        )
    );

const typeDefs = (names: string[]) =>
    ts.factory.createNodeArray(
        names.flatMap((name) => [
            brandedTypeDecl(name),
            wrapFuncDef(name),
            unwrapFuncDef(name),
        ])
    );

export const genCode = (file: string, typeNames: string[]) => {
    const program = ts.createProgram([file], {});
    const sourceFile = program.getSourceFile(file)!;
    const printer = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed });
    const code = printer.printList(
        ts.ListFormat.MultiLine,
        typeDefs(typeNames),
        sourceFile
    );
    writeFileSync(file, code);
};
