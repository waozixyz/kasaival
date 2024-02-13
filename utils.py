# utils.py
def convert_coordinates(x, y, offset_x, offset_y, scale_factor):
    """
    Convert actual screen coordinates to virtual screen coordinates.
    """
    virtual_x = (x - offset_x) / scale_factor
    virtual_y = (y - offset_y) / scale_factor
    return int(virtual_x), int(virtual_y)
    