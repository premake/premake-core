using System;
using System.Reflection;
using System.Resources;

public class CsConsoleApp
{
	static int Main()
	{
		Assembly assembly = Assembly.GetExecutingAssembly();
		ResourceManager resx = new ResourceManager("CsConsoleApp.Resources", assembly);
		string greeting = resx.GetString("Greeting");
		Console.WriteLine(greeting);

		Console.WriteLine("CsConsoleApp");

		CsSharedLib lib = new CsSharedLib();
		lib.DoIt();

		return 0;
	}
}
