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
    ast.map(function(l){
        write(line(l));
    });
    fs.writeFileSync("output/output.js", output);
    //eval(output);
}

function line(l){
    if(l.type === "mapping"){
        return "var "+ l.id + " = " + expression(l.expression);
    } else {
        return expression(l);
    }
}

function expression(e){
    if(e.type){
		if (e.type==="id"){
            return e.val;
        }
		if(e.type ==="array"){
			return "sf.flow(["+e.val.map(function(a){
				return expression(a);
			})+"])";
		}
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
            return "function($){\n"+e.args.map(function(e,c){
                return "var "+e+"=$["+c+"];";
            }).join("")+e.expression.map(function(a,c){
                if(c===e.expression.length-1){
                    return "return "+line(a)+";\n";
                }
                return line(a)+";\n";
            }).join("")+"}";
        }

        if(e.type==="when"){
            return "sf.when("+expression(e.expression)+","+expression(e.then)+","+expression(e.else)+")";
        }

		if(e.type==="unfold"){
			return "sf.unfold("+e.array+",function("+e.id+"){return "+expression(e.expression)+"})";
		}
    }

    return e;
}


module.exports = generate;
