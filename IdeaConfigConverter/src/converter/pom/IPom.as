/**
 * Created with IntelliJ IDEA.
 * User: sms
 * Date: 11/22/12
 * Time: 7:07 PM
 * To change this template use File | Settings | File Templates.
 */
package converter.pom {
	import converter.Iml;

	public interface IPom {
		function get data() : String;

		function getFilePath() : String;

		function get iml() : Iml;
	}
}
