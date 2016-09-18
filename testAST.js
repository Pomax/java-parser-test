var AST = require('./AST.json');
var sketch = AST.types[0].bodyDeclarations;
console.log(sketch.length);

let global = {};

function parseFieldValue(fragment) {
  let init = fragment.initializer;
  if (init) {
    let type = init.node;
    if (type === 'NumberLiteral') {
      return parseFloat(init.token);
    }
    if (type === 'StringLiteral') {
      let a = new String(init.escapedValue);
      return a.substring(1,a.length-1)
    }
    if (type === 'NullLiteral') {
      return null;
    }
  }
  return null;
}

function parseFieldDeclaration(node, parent) {
  let type = node.type;
  node.fragments.forEach(fragment => {
    let varname = fragment.name.identifier;
    let varvalue = parseFieldValue(fragment)
    parent[varname] = varvalue;
  });
}

function parseMethodDeclaration(node, parent) {
  console.log(node);
}

function parseTypeDeclaration(node, parent) {
  let name = node.name.identifier;

  global[name] = function() {};
  global[name].prototype = {};

  body = node.bodyDeclarations;
  body.forEach(e => parse(e, global[name]));
}

function parse(node, parent) {
  if (node.node === 'TypeDeclaration') {
    parseTypeDeclaration(node, parent)
  }
  else if (node.node === 'FieldDeclaration') {
    parseFieldDeclaration(node, parent)
  }
  else if (node.node === 'MethodDeclaration') {
    parseMethodDeclaration(node, parent)
  }
  else {
    console.log(node.node);
  }
}

parse(sketch[0]);
console.log(global);
