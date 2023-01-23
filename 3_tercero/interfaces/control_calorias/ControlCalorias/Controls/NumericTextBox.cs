using System.Globalization;
using System.Windows.Controls;
using System.Windows.Input;

namespace ControlCalorias.Controls
{
    public class NumericTextBox : TextBox
    {
        public NumericTextBox()
        {
            PreviewTextInput += NumericTextBox_PreviewTextInput;
        }

        public int IntValue
        {
            get
            {
                try
                {
                    return int.Parse(Text);
                }
                catch
                {
                    return -1;
                }
            }
        }

        public void NumericTextBox_PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            NumberFormatInfo numberFormatInfo = NumberFormatInfo.InvariantInfo;
            string decimalSeparator = numberFormatInfo.NumberDecimalSeparator;
            string negativeSign = numberFormatInfo.NegativeSign;
            string caracter = e.Text;

            if (!(char.IsDigit(e.Text[0]) || caracter.Equals(decimalSeparator) ||
                  caracter.Equals(negativeSign) || caracter == "\b"))
            {
                e.Handled = true;
            }
        }
    }
}
