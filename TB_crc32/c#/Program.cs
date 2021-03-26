using System;

namespace c_
{
    class Program
    {
        static void Main(string[] args)
        {
           string l=@"Конвертим файл! из hex8 в hex32";
           Console.WriteLine(l);
           bool error;
           string text="";
           string [] Arr;
           string str0="";
           string str1="";
           char [] zzz={'\n','\r'};
             try
            {
                if (args.Length != 0)
                {
                    foreach (string s in args)  Console.WriteLine(s);
                    text = System.IO.File.ReadAllText(args[0]);
                }
                else text = System.IO.File.ReadAllText("tst1.txt");
                error = false;
            }
         
            catch
            {
                Console.WriteLine("нет файла!");
                error = true;
            }

           if (error==false)
           {
               int k=0;
               for (int i=0;i<text.Length;i++)
               {
                   if (text[i]!=' '&&text[i]!='\n'&&text[i]!='\r') {str0=str0+text[i];k=0;}
                   else 
                   {
                       if (k==0) 
                       {
                           str0=str0+" ";
                           k=1;
                        }
                   }
               }
               
               Arr=str0.Split(" ");
                k=0;
               foreach(string s in Arr) 
               {
                   if (s.Length==2) 
                   {
                       if (k<3) 
                       {
                         str1=str1+s;
                         k++;
                       } else
                       {
                           k=0;
                           str1=str1+s+" ";
                       }
                       
                   }
               }

                Console.WriteLine(str1);
           }

           
           //Arr=str1.Split(" ");

            
       //     Console.ReadLine();
            Console.WriteLine("Записали hex.txt");
            System.IO.File.WriteAllText("hex.txt", str1);
        }
    }
}
