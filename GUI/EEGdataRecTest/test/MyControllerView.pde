//ControllerView to Modify the behavior and the shape color size of each controller
class start_button_view implements ControllerView<Button> {

  public void display(PGraphics pg, Button theButton) {
    pg.pushMatrix();
    if (theButton.isInside()) {
      if (theButton.isPressed()) { // button is pressed
        pg.fill(200, 60, 0);
      }  else { // mouse hovers the button
        pg.fill(200, 160, 100);
      }
      }
     else { // the mouse is located outside the button area
      pg.fill(0, 160, 100);
    }
    pg.ellipseMode(CORNER);
    pg.strokeWeight(4);
    fill(color(#57068C)); 
    pg.stroke(color(#A56060));
    
    pg.ellipse(0, 0, 91, 41);
   
    fill(color(#ffffff));
    pg.textMode(CORNER);
    pg.textSize(30);
    pg.text(system_start?"stop":"start",12,30);

    
    // center the caption label 
    int x = 0;
    int y = 0;
    
    theButton.getCaptionLabel().setText("").draw(pg);
    
    pg.popMatrix();
  }
}
class OnOffButtonView implements ControllerView<Button>{
	color mouse_off_color;
	color mouse_on_color;
	color mouse_press_color;
	OnOffButtonView(color _m_off_c, color _m_on_c, color _m_p_c)
	{
		mouse_off_color = _m_off_c;
		mouse_on_color = _m_on_c;
		mouse_press_color = _m_p_c;

	}
	public void display (PGraphics pg,Button theButton){
	pg.pushMatrix();
	if (theButton.isInside()){
		pg.fill(mouse_on_color);
		if (theButton.isPressed())
			pg.fill(mouse_press_color);
	}
	else{
		pg.fill(mouse_on_color);
	}
	pg.ellipseMode(CORNER);
	pg.ellipse(0, 0, theButton.getWidth(), theButton.getHeight());
	theButton.getCaptionLabel().setFont(font).draw(pg);
}
}
