var fs = require("fs");

var output = "";
function write(line){
    output += line + ";\n";
}

function requires(){
    write('var sf = require("./stockflow")');
    write('var sfstd = require("./stockflowstd")');
}

function generate(ast){
    //requires();
    ast.map(function(line){
        if(line.type === "mapping"){
            write( "var "+ line.id + " = " + expression(line.expression));
        }
        if(line.type === "expression"){
            write(expression(line));
        }
    });
    fs.writeFileSync("output/output.js", output);
    //eval(output);
}

function expression(e){
    if(e.type){
        if (e.type==="expression"){
            var args = e.args.map(function(a){
                return expression(a);
            });
            return e.mod+"(["+args+"])";
        }

        if (e.type==="stdexpression"){
            var args = e.args.map(function(a){
                return expression(a);
            });
            return "sfstd."+e.mod+"(["+args+"])";
        }

        if(e.type==="flow"){
            return "sf.flow(" + e.val + ")";
        }

        if(e.type==="mapper"){
            return "function($){"+e.args.map(function(e,c){
                return "var "+e+"=$["+c+"];";
            }).join("")+"return "+expression(e.expression)+";}";
        }

        if(e.type==="when"){
            return "sf.when("+expression(e.expression)+","+expression(e.then)+","+expression(e.else)+")";
        }
    }
    return e;
}


module.exports = generate;
