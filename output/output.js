var multandadd = function($){
var a=$[0];var b=$[1];var c=$[2];return sfstd.mult([a,sfstd.add([b,c])]);
};
var a = multandadd([sf.flow(1),sf.flow(2),sf.flow(3)]);
watch([a]);
