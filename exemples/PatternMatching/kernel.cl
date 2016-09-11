void __kernel PatternMatcher(                                                 
   __global char* pattern_string, const unsigned long pattern_length,
   __global char* buffer_string,  const unsigned long buffer_length,                                             
   __global unsigned long* results)                                                                                   
{                                                                      
   int i = get_global_id(0);                                           
   if(i == 0)
   	   results[0] = 1;
}                                                                  
