using UnityEngine;

public class BackgroundParallax : MonoBehaviour
{
    [SerializeField] private float parallaxEffectSpeed;
    
    private float _startPositionX, _lenghtParallaxEffect;
    private Camera _camera;
    
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        _camera = Camera.main;
        _startPositionX = transform.position.x;
        _lenghtParallaxEffect = GetComponent<SpriteRenderer>().bounds.size.x; 
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        float distance = _camera.transform.position.x * parallaxEffectSpeed;
        float movement = _camera.transform.position.x * (1 - parallaxEffectSpeed);
        
        transform.position = new Vector3(_startPositionX + distance, transform.position.y, transform.position.z);

        if (movement > _startPositionX + _lenghtParallaxEffect)
        {
            _startPositionX += _lenghtParallaxEffect;
        }
        else if (movement < _startPositionX - _lenghtParallaxEffect)
            _startPositionX -= _lenghtParallaxEffect;
    }
}
