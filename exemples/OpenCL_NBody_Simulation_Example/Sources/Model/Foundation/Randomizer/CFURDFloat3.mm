/*
 <samplecode>
 <import>CFURDFloat3.h</import>
 </samplecode>
 */

#import "CFURDFloat3.h"

using namespace CF;

URDFloat3::URDFloat3(const float& min, const float& max)
{
    // Default bounds for the uniform integer distribution
    mnMin = min;
    mnMax = max;
    
    // Acquire a random device for initializing our engine
    std::random_device  device;
    
    // Initialize the uniform Real distribution for
    // random number generation
    m_Generator    = std::default_random_engine(device());
    m_Distribution = std::uniform_real_distribution<float>(mnMin, mnMax);
} // Constructor

URDFloat3::URDFloat3(const URDFloat3& rObject)
{
    mnMin = rObject.mnMin;
    mnMax = rObject.mnMax;
    
    m_Generator    = rObject.m_Generator;
    m_Distribution = rObject.m_Distribution;
} // Copy Constructor

URDFloat3::~URDFloat3()
{
    mnMin = 0.0f;
    mnMax = 0.0f;
    
    m_Distribution.reset();
} // Destructor

URDFloat3& URDFloat3::operator=(const URDFloat3& rObject)
{
    if(this != &rObject)
    {
        mnMin = rObject.mnMin;
        mnMax = rObject.mnMax;
        
        m_Generator    = rObject.m_Generator;
        m_Distribution = rObject.m_Distribution;
    } // if
    
    return *this;
} // Assignment Operator

// Get the greatest lower bound
const float URDFloat3::min() const
{
    return mnMin;
} // min

// Get the least upper bound
const float URDFloat3::max() const
{
    return mnMax;
} // max

// Reset the distribution such that subsequent values generated
// are independent of previously generated values
void URDFloat3::reset()
{
    m_Distribution.reset();
} // reset

// Generate a random simd float3 vector using uniform real distribution
simd::float3 URDFloat3::rand()
{
    simd::float3 rand = {0.0f, 0.0f, 0.0f};
    
    rand.x = m_Distribution(m_Generator);
    rand.y = m_Distribution(m_Generator);
    rand.z = m_Distribution(m_Generator);
    
    return rand;
} // rand
