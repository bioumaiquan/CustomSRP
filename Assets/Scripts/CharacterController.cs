using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterController : MonoBehaviour
{
    [SerializeField]
    float speed = 1;
    [SerializeField]
    float maxAcceleration = 1;
    [SerializeField]
    Rect allowAera = new Rect(-5, -5, 10, 10);
    [SerializeField, Range(0,1)]
    float bounciness = 0.5f;

    void Start()
    {
        
    }

    Vector3 velocity;
    void Update()
    {
        Vector2 playerInput;
        playerInput.x = Input.GetAxis("Horizontal");
        playerInput.y = Input.GetAxis("Vertical");
        playerInput = Vector2.ClampMagnitude(playerInput, 1f);

        Vector3 desiredVelocity = new Vector3(playerInput.x, 0, playerInput.y) * speed;
        float maxSpeedChange = maxAcceleration * Time.deltaTime;
            
        velocity.x = Mathf.MoveTowards(velocity.x, desiredVelocity.x, maxSpeedChange);
        velocity.z = Mathf.MoveTowards(velocity.z, desiredVelocity.z, maxSpeedChange);


        Vector3 displacement = velocity * Time.deltaTime;
        Vector3 newPosition = transform.position + displacement;

        if (newPosition.x < allowAera.xMin)
        {
            newPosition.x = allowAera.xMin;
            velocity.x = -velocity.x * bounciness;
        }
        else if(newPosition.x > allowAera.xMax)
        {
            newPosition.x = allowAera.xMax;
            velocity.x = -velocity.x * bounciness;
        }

        if (newPosition.z < allowAera.yMin)
        {
            newPosition.z = allowAera.yMin;
            velocity.z = -velocity.z * bounciness;
        }
        else if (newPosition.z > allowAera.yMax)
        {
            newPosition.z = allowAera.yMax;
            velocity.z = -velocity.z * bounciness;
        }

        transform.position = newPosition;

    }
}
