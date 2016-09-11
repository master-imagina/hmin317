/*
 <samplecode>
 <abstract>
 Utility classes for generating random values using real uniform distribution for a simd float3 vector with aleast upper bound and a greatest lower bound
 </abstract>
 </samplecode>
 */


#ifndef _CORE_UNIFORM_REAL_DISTRIBUTION_FLOAT3_H_
#define _CORE_UNIFORM_REAL_DISTRIBUTION_FLOAT3_H_

#import <random>

#import <simd/simd.h>

#ifdef __cplusplus

namespace CF
{
    class URDFloat3
    {
    public:
        URDFloat3(const float& min = 0.0f, const float& max = 1.0f);
        
        URDFloat3(const URDFloat3& rObject);
        
        virtual ~URDFloat3();
        
        URDFloat3& operator=(const URDFloat3& rObject);

        const float min() const;
        const float max() const;
        
        void reset();

        simd::float3 rand();
        
    private:
        float  mnMin;  // Greatest lower bound for uniform integer distribution
        float  mnMax;  // Least upper bound for uniform integer distribution
        
        // Uniform discrete real distribution:
        //
        // <http://www.cplusplus.com/reference/random/uniform_real_distribution/>
        //
        // The valid type names here are float, double, or long double.
        std::default_random_engine             m_Generator;
        std::uniform_real_distribution<float>  m_Distribution;
    };
} // CF

#endif

#endif
