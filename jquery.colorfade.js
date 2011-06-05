/*
 * @purpose Calculates a heat index for an element and applies a bg color (blue through red)
 * @argument srcFn: Callback that returns an integer complexity index for each element
 * @argument targetFn: Callback that returns the element to apply the heat index to
 * @author Nathan Strutz
 * @contact strutz@gmail.com
 */
jQuery.fn.colorFade = function(srcFn,targetFn){
	var $=jQuery;
	var maxComplexity = 1;

	var getHeat = function(maxComplexity,currentComplexity) {
		var rowRedness = (currentComplexity * 255) / maxComplexity;
		return parseInt(rowRedness);
	}

	return this.each(function(i){
		var complexity = srcFn.call(this);
		if (complexity>maxComplexity) {
			maxComplexity = complexity;
		}
	}).each(function(i){
		var t = $(this);
		var lineComplexity = srcFn.call(this);
		var lineHeat = getHeat(maxComplexity, lineComplexity);
		$(targetFn.call(this)).css("background-color", "rgb("+ lineHeat +","+ parseInt(255-(lineHeat/1.5)) +","+ parseInt(255-(lineHeat/1.5)) +")");
	});
}